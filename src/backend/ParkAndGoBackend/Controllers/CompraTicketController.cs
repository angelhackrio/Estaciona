using ParkAndGoBackend.Entity;
using ParkAndGoBackend.Entity.Pagamento;
using ParkAndGoBackend.Entity.Reversa;
using ParkAndGoBackend.Entity.User;
using ParkAndGoBackend.Models;
using ParkAndGoBackend.Services.Payment.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

namespace ParkAndGoBackend.Controllers
{
    [Route("api/Ticket")]
    public class CompraTicketController : ApiController
    {
        private ParkAndGoDbContext Db { get; } = new ParkAndGoDbContext();

        [ResponseType(typeof(List<Ticket>))]
        public IHttpActionResult GetTicket([Required] string userDeviceToken, [Required] string placaDeCarro)
        {
            if (!ModelState.IsValid)
            {
               return BadRequest();
            }

            var model = (from e in Db.Ticket
                         where e.UserDeviceToken == userDeviceToken
                         where e.PlacaDoCarro == placaDeCarro
                         orderby e.DataInicioDoSlot descending
                         select e).ToList();

            return Ok(model);
        }

        [Route("api/Estacionamentos/NaoExpirados")]
        [ResponseType(typeof(List<Ticket>))]
        public IHttpActionResult GetTicketNaoExpirados([Required] string userDeviceToken, [Required] string placaDeCarro)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest();
            }

            var model = (from e in Db.Ticket
                         where e.UserDeviceToken == userDeviceToken
                         where e.PlacaDoCarro == placaDeCarro
                         where e.DataInicioDoSlot >= DateTimeOffset.Now.AddDays(-1)
                         where e.DataInicioDoSlot <= DateTimeOffset.Now
                                || e.DataFimDoSlot >= DateTimeOffset.Now.AddHours(-1)
                         orderby e.DataInicioDoSlot descending
                         select e).ToList();

            return Ok(model);
        }


        public IHttpActionResult PostTicket([Required] TicketModel ticketModel)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest();
            }

            var existeOEstacionamento = Db.Estacionamentos.Any(e => e.Id == ticketModel.Estacionamento.Id);
            if (!existeOEstacionamento)
                return NotFound();

            var userDeviceExistente = Db.UserDevices.Where(t => t.Token == ticketModel.UserDeviceToken).SingleOrDefault();
            var userDivive = userDeviceExistente ?? new Entity.User.UserDevice { Id = Guid.NewGuid(), Token = ticketModel.UserDeviceToken };
            if(userDeviceExistente == null)
            {
                Db.UserDevices.Add(userDivive);
            }

            var tempoDeInicioInvalido = ticketModel.DataInicioDoSlot <= DateTimeOffset.Now.AddDays(-1);
            if (tempoDeInicioInvalido)
                return BadRequest();

            ////////////////

            var novoTicket = new Ticket
            {
                Id = Guid.NewGuid(),
                CreatedAt = DateTimeOffset.Now,

                EstacionamentoId = ticketModel.Estacionamento.Id,
                PlacaDoCarro = ticketModel.PlacaDoCarro,
                UserDeviceToken = ticketModel.UserDeviceToken,
                DataInicioDoSlot = ticketModel.DataInicioDoSlot,
                DataFimDoSlot = ticketModel.DataInicioDoSlot.Value.AddHours(ticketModel.IntervaloComprado.Value),
                PrecoPagoEmCentavos = ticketModel.PrecoAPagarEmCentavos,
                IntervaloComprado = ticketModel.IntervaloComprado,
            };
            novoTicket.DetalhePagamento = Cobrar(ticketModel, userDivive);
           
            Db.Ticket.Add(novoTicket);
            Db.SaveChanges();

            return Ok(novoTicket.Id);
        }

        private DetalhePagamento Cobrar(TicketModel ticketModel, UserDevice device)
        {
            if(ticketModel == null)
            {
                return new DetalhePagamento
                {
                    Id = Guid.NewGuid(),
                    PagoComSucesso = true,
                    CartaoDeCreditoSalvo = new Entity.Pagamento.SavedCreditCard
                    {
                        CreditCardBrand = CreditCardBrand.Visa,
                        MaskedCreditCardNumber = "12345567890",
                        CreatedAt = DateTimeOffset.Now,
                        UserDevice = device,
                    }
                };
            }

            var dadosPagamento = ticketModel.DadosDeCobranca;

            var pagamentoService = new ParkAndGoBackend.MundipaggService.MundpaggPaymentService();
            var result = pagamentoService.PayWithCreditCard(dadosPagamento);

            var result2 = new DetalhePagamento
            {
                Id = Guid.NewGuid(),
                PagoComSucesso = result.PaymentBilledSuccessful,
                CartaoDeCreditoSalvo = new Entity.Pagamento.SavedCreditCard
                {
                    CreditCardBrand = result.SavedCreditCard.CreditCardBrand,
                    MaskedCreditCardNumber = result.SavedCreditCard.MaskedCreditCardNumber,
                    CreatedAt = DateTimeOffset.Now,
                    UserDevice = device,
                }
            };

            return result2;
        }
    }
}
