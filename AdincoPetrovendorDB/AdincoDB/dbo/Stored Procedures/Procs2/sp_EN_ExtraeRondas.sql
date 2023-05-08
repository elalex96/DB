-- ==
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama las rondas
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeRondas]--3,10061
	@idContrato INT,
	@idUsuario INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT idRonda, Ronda FROM en_Rondas
END
