using ParkAndGoBackend.Entity;
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace ParkAndGoBackend.Models
{
    public class DadosDeCobranca
    {
        [Required]
        public virtual Guid? BoughtTicketId { get; set; }

        [Required]
        [DisplayName("Deseja Salvar o Cartão")]
        public virtual bool UserRequestToSaveCreditCard { get; set; }

        [Required]
        [DisplayName("Nome como no Cartão")]
        public string HolderName { get; set; }

        [Required, CreditCard]
        [DataType(DataType.CreditCard)]
        [DisplayName("Numero do Cartão")]
        public string CreditCardNumber { get; set; }

        [Required]
        [DisplayName("Codigo de segurnaça")]
        public string SecurityCode { get; set; }

        [Required]
        [Range(1, 12)]
        [DisplayName("Mês de Expiração")]
        public int? ExpMonth { get; set; }
        [Required]
        [Range(16, 30)]
        [DisplayName("Ano de Expiração")]
        public int? ExpYear { get; set; }

        [Required]
        [DisplayName("Bandeira")]
        public CreditCardBrand? CreditCardBrand { get; set; }
    }
}