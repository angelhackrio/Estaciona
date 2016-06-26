using ParkAndGoBackend.Entity.Estacionamento;
using System.Collections.Generic;

namespace ParkAndGoBackend.Controllers
{
    public class EstacionamentosProximosModel
    {
        public virtual List<Estacionamento> Estacionamentos { get; set; }
    }
}