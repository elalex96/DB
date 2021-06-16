-- =============================================
-- Author:	Alexander Gomez
-- Update: 15-06-2021
-- Description:	Validacion de Operadora para CARTA CN PR A PR
-- =============================================

CREATE PROCEDURE [dbo].[SP_DEA_ValidarProveedor_CARTACN]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int, 
	@IdAceptacion INT
AS
BEGIN
	DECLARE @RFC_ACTUAL NVARCHAR(200), @EXISTE_RFC INT;

	set @RFC_ACTUAL = (SELECT TOP 1
							P.RFC
						FROM dbo.MM_AceptacionPedido AS AP
						JOIN dbo.S_Proveedor AS P ON AP.IdProveedor = P.IdProveedor
						WHERE AP.IdAceptacionPedido = @IdAceptacion);

	set @EXISTE_RFC = (SELECT COUNT(IdProveedor) 
						FROM DEA_Proveedor 
						WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) 
						AND Activo = 1)

	IF ISNULL(@EXISTE_RFC,0)  >0 
	BEGIN 
		SELECT 'CAMBIAR_PROCESO'
	END 
	ELSE 
	BEGIN 
		SELECT 'SEGUIR_PROCESO'
	END 

END