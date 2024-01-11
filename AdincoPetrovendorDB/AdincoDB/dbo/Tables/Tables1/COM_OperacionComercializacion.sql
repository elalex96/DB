CREATE TABLE [dbo].[COM_OperacionComercializacion] (
    [IdOperacionComercializacion]   INT           IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                    INT           NULL,
    [MesReporte]                    DATE          NULL,
    [FechaTransaccion]              DATE          NULL,
    [IdTipoHidrocarburo]            INT           NULL,
    [VolumenVendido]                FLOAT (53)    NULL,
    [PrecioVentaUnitario]           MONEY         NULL,
    [CostoUnitarioComercializacion] MONEY         NULL,
    [PrecioPuntoMedicion]           MONEY         NULL,
    [IdFactura]                     INT           NULL,
    [NumeroFolioPedimento]          NVARCHAR (15) NULL,
    [EPT]                           BIT           NULL,
    [OperacionBajoReglasMercado]    BIT           NULL,
    [ClasificacionDocumentoSoporte] INT           NULL,
    [CreadoPor]                     INT           NULL,
    [CreadoEl]                      DATETIME      NULL,
    [ModificadoPor]                 INT           NULL,
    [ModificadoEl]                  DATETIME      NULL,
    [Activo]                        BIT           NULL,
    [PVUAnterior]                   MONEY         NULL,
    [PPMAnterior]                   MONEY         NULL,
    [NuevoPrecioVentaUnitario]      MONEY         NULL,
    [PuntoEntregaID]                INT           NULL,
    [EsCondensable]                 BIT           DEFAULT ((0)) NULL,
    [PenaEconomica]                 FLOAT (53)    NULL,
    [IdCromatografiaArchivo]        INT           NULL,
    CONSTRAINT [PK_COM_OperacionComercializacion] PRIMARY KEY CLUSTERED ([IdOperacionComercializacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_COM_OperacionComercializacion_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_COM_OperacionComercializacion_CO_TipoHidrocarburo] FOREIGN KEY ([IdTipoHidrocarburo]) REFERENCES [dbo].[CO_TipoHidrocarburo] ([IdTipoHidrocarburo])
);


GO
CREATE NONCLUSTERED INDEX [idx_ContratoMes]
    ON [dbo].[COM_OperacionComercializacion]([IdContrato] ASC, [MesReporte] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO

CREATE TRIGGER [dbo].[Trigger_ActualizaPrecioRegalias] ON [dbo].[COM_OperacionComercializacion]
AFTER INSERT, UPDATE
AS
BEGIN
-- =============================================-- Author:		Miguel Gomez-- Create date: -- Description:	-- =============================================
   -- 20180406	BAAC	Se modifica para que afecte todos los registros insertados
         SET NOCOUNT ON;
    --     DECLARE @IdContrato INT;
    --     DECLARE @Mes DATE;
	   -- DECLARE @Id AS INT

    --     SELECT @IdContrato = idcontrato,
    --            @mes = mesreporte,
			 --@Id = IdOperacionComercializacion
    --     FROM inserted;
    --     --EXEC sp_CP_CalculaPrecioContractualPetroleo
    --     --     @IdContrato,
    --     --     @mes;
    --     ---- Insert statements for trigger here
	   -- update [COM_OperacionComercializacion]set MesReporte  =   DATEFROMPARTS(year(FechaTransaccion),MONTH(FechaTransaccion),1)
	   -- where IdOperacionComercializacion  =@Id

		UPDATE	OC
			SET	MesReporte  =   DATEFROMPARTS(YEAR(I.FechaTransaccion),MONTH(I.FechaTransaccion),1)
        FROM
			INSERTED	I
		JOIN
			COM_OperacionComercializacion	OC
			ON	I.IdOperacionComercializacion	=	OC.IdOperacionComercializacion

END
