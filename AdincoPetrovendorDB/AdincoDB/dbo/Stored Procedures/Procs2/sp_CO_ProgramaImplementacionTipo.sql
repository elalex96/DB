-- =============================================
-- Author:		Reyna Olvera
-- Create date: 26/08/2019
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ProgramaImplementacionTipo]
    @idUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
	Id,
	Descripcion
    FROM CO_ProgramaImplementacionTipo 
	WHERE IdContrato=@IdContrato
	AND IsEliminado=0
END;
