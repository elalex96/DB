-- =============================================
-- Author:		Manuel Cruz
-- Create date: 22-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE sp_FI_InsertarPedimentoImportacion

	-- Add the parameters for the stored procedure here
@IdContrato                 INT,
@NumeroPedimento            NVARCHAR(50),
@ClavePedimento             NVARCHAR(50),
@FechaPago                  DATE,
@Regimen                    NVARCHAR(200),
@IdSubcontratistaImportador INT,
@AduanaES                   NVARCHAR(50),
@IdSubcontratistaExportador INT,
@IdMoneda                   INT,
@AcuseElectronico           NVARCHAR(200),
@IdEstudioPrecioTransfer    INT,
@DescripcionMercancia       NVARCHAR(MAX),
@PrecioUnitario             MONEY,
@Cantidad                   INT,
@FolioComprobante           NVARCHAR(50)
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @IdPedComp INT
    -- Insert statements for procedure here
         INSERT INTO [dbo].[FI_PedimentoComprobante]
         ([IdContrato],
          [NumeroPedimento],
          [ClavePedimento],
          [FechaPago],
          [Regimen],
          [IdSubcontratistaImportador],
          [AduanaES],
          [IdSubcontratistaExportador],
          [IdMoneda],
          [AcuseElectronico],
          [IdEstudioPrecioTransfer],
          [CvTipoDocFacturacion],
          [ProcesadoSIPAC]
         )
         VALUES
         (@IdContrato,
          @NumeroPedimento,
          @ClavePedimento,
          @FechaPago,
          @Regimen,
          @IdSubcontratistaImportador,
          @AduanaES,
          @IdSubcontratistaExportador,
          @IdMoneda,
          @AcuseElectronico,
          @IdEstudioPrecioTransfer,
          2,
          0
         )

         SET @IdPedComp = (SELECT @@IDENTITY AS INSERTADO)

         INSERT INTO [dbo].[FI_PedimentoComprobanteDetalle]
         ([IdPedimentoComprobante],
          [DescripcionMercancia],
          [PrecioUnitario],
          [Cantidad]
         )
         VALUES
         (@IdPedComp,
          @DescripcionMercancia,
          @PrecioUnitario,
          @Cantidad
         )
         IF @@ERROR <> 0
				SELECT 'false' AS msj;
             ELSE
				SELECT 'true' AS msj;
     END

	--EXEC sp_FI_InsertarPedimentoImportacion 3,'123','1','2017-05-22','123',10000,'AB',10285,1,'987',1,'TEST2',1,1,'456'
