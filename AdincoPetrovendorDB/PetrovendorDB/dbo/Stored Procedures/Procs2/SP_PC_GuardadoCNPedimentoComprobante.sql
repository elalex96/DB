-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/04/2020>
-- Description:	<Guardado del detalle de cn de pedimento comprobante>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_GuardadoCNPedimentoComprobante]
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT,
	@IdProveedor INT,
	@IdContrato INT,
	@IdUsuario INT,
	@ConceptosCN ConceptosCNCompraDirecta READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @TOTALINSERTADOS INT = (SELECT COUNT(1) FROM @ConceptosCN);

	INSERT INTO dbo.CN_CompraDirecta
	(
	    IdContrato,
	    IdProveedor,
	    DescripcionBienesServicios,
	    ValorFactura,
	    PCN,
	    IdActividadBS,
	    ClasificacionSH,
	    Activo,
		CreadoPor,
		CreadoEl,
		IdPedimentoComprobante
	)
	SELECT
		@IdContrato,
		@IdProveedor,
		CNC.DescripcionBienesServicios,
		CNC.ValorFactura,
		CNC.PCN,
		CASE 
			WHEN CNC.IdActividadBS = 0 THEN NULL
			ELSE CNC.IdActividadBS
		END,
		CNC.ClasificacionSH,
		1,
		@IdUsuario,
		GETDATE(),
		@IdPedimentoComprobante
	FROM @ConceptosCN AS CNC;

	IF @@ROWCOUNT = @TOTALINSERTADOS
	BEGIN
	    
		SELECT 'true' AS REGISTROSGUARDADOS

	END
	ELSE
	BEGIN
	    
		SELECT 'false' AS REGISTROSGUARDADOS

	END

END
