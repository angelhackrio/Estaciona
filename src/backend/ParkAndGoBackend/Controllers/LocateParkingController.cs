using ParkAndGoBackend.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

namespace ParkAndGoBackend.Controllers
{
    [Route("api/Estacionamentos")]
    public class LocateParkingController : ApiController
    {

        private ParkAndGoDbContext Db { get; } = new ParkAndGoDbContext();

        [ResponseType(typeof(EstacionamentosProximosModel))]
        public IHttpActionResult GetNearParking()
        {
            var model = new EstacionamentosProximosModel()
            {
                Estacionamentos = (from e in Db.Estacionamentos
                                   orderby e.Nome
                                   select e).ToList(),
            };

            return Ok(model);
        }
    }
}
