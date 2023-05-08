-- =============================================
-- Author:		Manuel Cruz
-- Create date: 23-04-2018
-- Description:	
-- =============================================
create PROCEDURE [dbo].[ET_ConsultaEscalaTiempo]
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT ET.IdEscalaTiempo,
                    ET.NombreEscalaTiempo,
                    COUNT(A.Parte) AS ContParte
             INTO #EscalaTiempo
             FROM dbo.ET_EscalaTiempo ET
                  JOIN dbo.ET_Actividad A ON A.IdEscalaTiempo = ET.IdEscalaTiempo
             GROUP BY ET.IdEscalaTiempo,
                      ET.NombreEscalaTiempo,
                      A.Parte;
		   --
             SELECT IdEscalaTiempo,
                    NombreEscalaTiempo,
                    COUNT(IdEscalaTiempo) AS CantLineas
             FROM #EscalaTiempo
             GROUP BY IdEscalaTiempo,
                      NombreEscalaTiempo
             ORDER BY IdEscalaTiempo;
         END;
--ET_ConsultaEscalaTiempo 1,2