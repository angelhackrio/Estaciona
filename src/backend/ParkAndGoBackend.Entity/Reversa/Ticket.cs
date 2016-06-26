using ParkAndGoBackend.Entity.Pagamento;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ParkAndGoBackend.Entity.Reversa
{
    [Table("Tickets", Schema = "Ticket")]
    public class Ticket
    {
        [Key, Required]
        public virtual Guid Id { get; set; }

        [Required]
        [ForeignKey(nameof(Estacionamento))]
        public virtual Guid? EstacionamentoId { get; set; }
        public virtual Estacionamento.Estacionamento Estacionamento { get; set; }

        [Index]
        [Required, StringLength(7)]
        public virtual string PlacaDoCarro { get; set; }

        [Required]
        public virtual string UserDeviceToken { get; set; }
        
        [Index]
        [Required]
        public virtual DateTimeOffset? DataInicioDoSlot { get; set; }

        [Required]
        public virtual DateTimeOffset? DataFimDoSlot { get; set; }

        [Required, Range(0, 1000d)]
        public int? IntervaloComprado { get; set; }

        [Required, Range(0, 1000000d)]
        public virtual long? PrecoPagoEmCentavos { get; set; }

        [Required]
        [ForeignKey(nameof(DetalhePagamento))]
        public virtual Guid? DetalhePagamentoId { get; set; }
        public virtual DetalhePagamento DetalhePagamento { get; set; }


        [Column("_createdAt")]
        public virtual DateTimeOffset CreatedAt { get; set; }
        [Column("_changedAt")]
        public virtual DateTimeOffset? ChangedAt { get; set; }

        [Timestamp, Column("_rowVersion")]
        public virtual byte[] RowVersion { get; set; }
    }
}
