-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12/09/2020>
-- Description:	<Validacion de PO para dea al aprobar factura>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ValidarPOFactura] --2337,420
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @RFC_ACTUAL NVARCHAR(MAX);
	DECLARE @EXISTE_PO NVARCHAR(MAX);
	SELECT @RFC_ACTUAL=RFC FROM dbo.S_Proveedor  (NOLOCK)  WHERE IdProveedor=@IdProveedor 

	DECLARE @EXISTE_RFC INT = (SELECT COUNT(IdProveedor) FROM DEA_Proveedor  (NOLOCK) WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) AND Activo=1)

	IF ISNULL(@EXISTE_RFC,0) > 0 
	BEGIN 

		SET @EXISTE_PO = (
							SELECT TOP 1
								PRPO.PO
							FROM dbo.MM_AceptacionPedido AS AP  (NOLOCK) 
								JOIN dbo.MM_Pedido AS P (NOLOCK) 
									ON AP.IdPedido = P.IdPedido 
								JOIN dbo.DEA_Relacion_PR_PO AS PRPO (NOLOCK) 
									ON P.IdPedido = PRPO.IdPedido 
							WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);

		IF @EXISTE_PO IS NOT NULL
		BEGIN
		    
			SELECT 1

		END
		ELSE
		BEGIN
		    
			SELECT 0

		END
	END 
	ELSE 
	BEGIN 
		SELECT 1
	END 

	
END
