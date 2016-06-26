using ParkAndGoBackend.Entity.User;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkAndGoBackend.Entity.Pagamento
{
    [Table("SavedCreditCards", Schema = "Pagamento")]
    public class SavedCreditCard
    {
        [Key, Required]
        public virtual Guid Id { get; set; }

        [Required]
        public virtual string IdOfSavedCardInTheGateway { get; set; }

        [Required]
        public virtual CreditCardBrand? CreditCardBrand { get; set; }

        [Required, StringLength(24)]
        public virtual string MaskedCreditCardNumber { get; set; }

        [Required, ForeignKey(nameof(UserDevice))]
        public virtual Guid UserDeviceId { get; set; }
        public virtual UserDevice UserDevice { get; set; }

        [Column("_createdAt")]
        public virtual DateTimeOffset CreatedAt { get; set; }
    }
}