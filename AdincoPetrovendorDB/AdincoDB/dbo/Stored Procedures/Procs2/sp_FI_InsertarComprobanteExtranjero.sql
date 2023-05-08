-- =============================================
-- Author:		Manuel Cruz
-- Create date: 22-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE sp_FI_InsertarComprobanteExtranjero

	-- Add the parameters for the stored procedure here
@IdContrato                 INT,
@FolioComprobante           NVARCHAR(50),
@FechaPago                  DATE,
@IdSubcontratistaImportador INT,
@IdFormaPago                INT,
@IdMoneda                   INT,
@IdEstudioPrecioTransfer    INT,
@IdUnidadMedida             INT,
@NumeroSerieMercancia       NVARCHAR(50),
@ClaseBienServicio          NVARCHAR(150),
@PrecioUnitario             MONEY,
@Cantidad                   INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @IdPedComp INT
    -- Insert statements for procedure here
         INSERT INTO [dbo].[FI_PedimentoComprobante]
         ([IdContrato],
          [FolioComprobante],
          [FechaPago],
          [IdSubcontratistaImportador],
          [IdFormaPago],
          [IdMoneda],
          [IdEstudioPrecioTransfer],
          [CvTipoDocFacturacion],
          [ProcesadoSIPAC]
         )
         VALUES
         (@IdContrato,
          @FolioComprobante,
          @FechaPago,
          @IdSubcontratistaImportador,
          @IdFormaPago,
          @IdMoneda,
          @IdEstudioPrecioTransfer,
          3,
          0
         )
         SET @IdPedComp = ( SELECT @@IDENTITY AS INSERTADO)

         INSERT INTO [dbo].[FI_PedimentoComprobanteDetalle]
         ([IdPedimentoComprobante],
          [IdUnidadMedida],
          [NumeroSerieMercancia],
          [ClaseBienServicio],
          [PrecioUnitario],
          [Cantidad]
         )
         VALUES
         (@IdPedComp,
          @IdUnidadMedida,
          @NumeroSerieMercancia,
          @ClaseBienServicio,
          @PrecioUnitario,
          @Cantidad
         )

         IF @@ERROR <> 0
				SELECT 'false' AS msj;
             ELSE
				SELECT 'true' AS msj;
     END

	--EXEC sp_FI_InsertarComprobanteExtranjero 3,'k-158480','2017-03-29',10000,1,2,2,1,A2512157,'Tubos',3500.00,24
