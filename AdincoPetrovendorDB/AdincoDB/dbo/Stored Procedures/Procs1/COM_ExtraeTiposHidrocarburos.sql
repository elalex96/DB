-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180817
-- Description:	Para combos que extraen los tipos de hidrocarburos
-- =============================================
CREATE PROCEDURE COM_ExtraeTiposHidrocarburos
	-- Add the parameters for the stored procedure here
	@idUsuario INT,
	@idContrato INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT IdTipoHidrocarburo,Hidrocarburo from CO_TipoHidrocarburo
END