-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Update: 25-01-2021
-- Description:	issue #930/ Optimización de sp
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Update: 08/07/2121
-- Description:	issue #1201/ Bug de dea carta de proveedor a operadora 
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
						AND Activo = 1
						AND RFC <> 'DDE151002QY9'
						)

	IF ISNULL(@EXISTE_RFC,0)  >0 
	BEGIN 
		SELECT 'CAMBIAR_PROCESO'
	END 
	ELSE 
	BEGIN 
		SELECT 'SEGUIR_PROCESO'
	END 

END