CREATE PROCEDURE [dbo].[SP_FI_ActualizarEstatusFacturaAdinco] 
	@IdFactura INT ,
	@ResponseAdinco NVARCHAR(MAX)
    
AS
BEGIN
-- =============================================
-- Author:		Miguel - DANIEL MODIFICACION
-- Create date: 5-12-16 - 17/08/2017
-- Description:	Consulta una factura
-- =============================================
	SET NOCOUNT ON;
-- =============================================
 
		UPDATE FI_Factura 
		SET IdEstatusEnviado = 8,
		ResponseAdinco = @ResponseAdinco,
		FechaEnvio = GETDATE()
		WHERE IdFactura = @IdFactura

		SELECT 'UPDATE ESTATUS PETROVENDOR'

		--REGISTRO DEL COMPLEMENTO DE PAGO EN ADINCO
		DECLARE @IDFACTURAADINCO INT;
		DECLARE @IDCONTRATO INT;
		DECLARE @IDUSUARIO INT;
		DECLARE @TEXTO NVARCHAR(23) = (SUBSTRING(@ResponseAdinco,0,23));
		---SE DESCARTA QUE SEA UN TEXTO ENVIADO POR EL WEBSERVICE O QUE VENGA VACIO
		IF ISNULL(@TEXTO,'') <> 'ID previamente cargado' OR ISNULL(@TEXTO,'') <> ''
		BEGIN
		    --SE CASTE A UN INT
			SET @IDFACTURAADINCO = CAST(ISNULL(@TEXTO,0) AS INT);

			--SE OBTIENEN LOS DEMAS DATOS PARA EL REGISTRO DEL COMPLEMENTO DE PAGO
			SELECT
				@IDCONTRATO = ISNULL(IdContrato,0),
				@IDUSUARIO = ISNULL(CreadoPor,0)
			FROM dbo.FI_Factura 
			WHERE IdFactura = @IdFactura;

			--SE ENVIA A ADINCO
			EXECUTE Adinco.dbo.sp_FI_GuardaFacturaPPDP_V2 @IDCONTRATO, -- int
			                                              @IDUSUARIO,  -- int
			                                              @IDFACTURAADINCO;   -- int
			
		END;
END
