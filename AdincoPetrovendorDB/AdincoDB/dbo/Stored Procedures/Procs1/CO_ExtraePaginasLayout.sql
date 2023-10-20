IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'CO_ExtraePaginasLayout'
)
    DROP PROCEDURE CO_ExtraePaginasLayout
GO
-- =============================================
-- Author:		Reyna Olvera
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraePaginasLayout]
	-- Add the parameters for the stored procedure here
	@idContrato int =0,
	@idUsuario int =0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT idPagina, Nombrepagina 
	FROM dbo.AP_PaginaLayout (NOLOCK)
	ORDER BY Nombrepagina
END