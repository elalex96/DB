-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeCalendarioRegulador]--3,10061
	@idContrato INT,
	@idUsuario INT
AS
BEGIN

	SET NOCOUNT ON;
Select 0 as IdRegulador,
'Calendario Default' as Regulador
UNION ALL 
SELECT R.IdRegulador as IdRegulador,
R.Regulador as Regulador FROM 
AP_CalendarioExcepciones CE
JOIN CO_Regulador R ON CE.IdRegulador=R.IdRegulador
Group by R.IdRegulador,R.Regulador,R.NombreRegulador;

END