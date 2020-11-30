-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200416
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeVersiones]--225,306594,3,10061
	@InstanciaEntregableId int,
	@idUsuario int,
	@idContrato int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IdLineaTiempo,  ROW_NUMBER() OVER (ORDER BY IdLineaTiempo) AS VERSION
	FROM 
		EN_HistorialAprobacionesLineaTiempo 
	WHERE
		idInstanciaEntregable	=	@InstanciaEntregableId
	GROUP BY 
		IdLineaTiempo
END