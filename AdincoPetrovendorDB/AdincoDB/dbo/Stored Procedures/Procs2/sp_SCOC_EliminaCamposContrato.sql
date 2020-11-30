-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181220
-- Description:Agrega campos del contrato
-- =============================================
CREATE PROCEDURE sp_SCOC_EliminaCamposContrato -- 3,10

    @idContrato INT,
    @idUsuario INT,
	@CampoID INT
AS
BEGIN

DELETE dbo.SCOC_CampoContrato
	WHERE CampoID=@CampoID AND IdContrato=@idContrato;

END;
