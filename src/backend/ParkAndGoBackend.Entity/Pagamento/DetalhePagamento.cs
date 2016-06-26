using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System;

namespace ParkAndGoBackend.Entity.Pagamento
{
    [Table("DetalhePagamentos", Schema = "Pagamento")]
    public class DetalhePagamento
    {
        [Key, Required]
        public virtual Guid Id { get; set; }

        public virtual SavedCreditCard CartaoDeCreditoSalvo { get; set; }

        public virtual bool PagoComSucesso { get; set; }
    }
}