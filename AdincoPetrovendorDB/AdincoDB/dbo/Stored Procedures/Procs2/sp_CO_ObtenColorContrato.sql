-- =============================================
-- Author:		Reyna Olvera
-- Create date:20200513
-- Description:Obten colores del contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ObtenColorContrato]
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT Color_Hex 
	FROM 
		CO_ContratoConfiguracion
	WHERE 
		IdContrato	=	@idContrato

END