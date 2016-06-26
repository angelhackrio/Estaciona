using ParkAndGoBackend.Entity.Estacionamento;
using ParkAndGoBackend.Services.Payment.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace ParkAndGoBackend.Models
{
    public class TicketModel
    {
        [Key]
        public virtual Guid? Id { get; set; }
        
        [Required]
        public virtual string UserDeviceToken { get; set; }

        [Required, StringLength(7)]
        public virtual string PlacaDoCarro { get; set; }

        [Required]
        public virtual EstacionamentoModel Estacionamento { get; set; }

        [Required]
        public virtual DateTimeOffset? DataInicioDoSlot { get; set; }

        [Required, Range(0, 1000000d)]
        public virtual long? PrecoAPagarEmCentavos { get; set; }

        [Required, Range(0, 1000d)]
        public int? IntervaloComprado { get; set; }

        public BillingWithNewCreditCard DadosDeCobranca { get; set; }
    }

    public class EstacionamentoModel
    {
        [Required]
        public virtual Guid? Id { get; set; }

        public virtual string Nome { get; set; }
    }
}