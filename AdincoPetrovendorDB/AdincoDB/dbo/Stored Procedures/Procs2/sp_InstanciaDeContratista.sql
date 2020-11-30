-- =============================================
-- Author:		Reyna Olvera
-- Create date: 09/04/2018
-- Description:	Visualiza los entregables internos
-- =============================================
CREATE PROCEDURE [dbo].[sp_InstanciaDeContratista]
	@idContrato INT,
    @idUsuario INT,
    @idInstancia INT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @IdContratista INT, @IdContratistaInstancia INT;

	SELECT @IdContratista	=	IdContratista	FROM	CO_Contrato	WHERE IdContrato=@idContrato
	
	SELECT @IdContratistaInstancia=C.IdContratista FROM EN_InstanciasEntregable	IE
	JOIN	EN_ContratoEntregable	CE
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND IE.idInstanciaEntregable	=	@idInstancia
	JOIN	CO_Contrato	C
		ON	CE.IdContrato	=	C.IdContrato

	IF(@IdContratista=@IdContratistaInstancia)
	BEGIN
		SELECT	'' AS EsDeContratista
	END
	ELSE
	BEGIN
		SELECT	'Entregable no perteneciente al contratista' AS EsDeContratista
	END
END