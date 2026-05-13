/****** Object:  StoredProcedure [dbo].[DiferidaPeriodo]    Script Date: 26/03/2017 06:42:54 p. m. ******/
-- =============================================
-- Author:		Miguel
-- Create date: 1-Jul-2013
-- Description:	Consulta de produccion diferida en un periodo
-- =============================================
CREATE PROCEDURE [dbo].[sp_PR_DiferidaPeriodo] 
	-- Add the parameters for the stored procedure here
	@inicio datetime , 
	@fin datetime  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT @inicio, @fin
	
SELECT     PR_Ramal.Nombre AS Ramal, PR_Estacion.Nombre AS Estacion, PR_Pozo.Nombre, PR_ListaGeneral.Nombre AS Sistema, PR_ParoDetalle.Inicio, PR_ParoDetalle.Fin, PR_RubroParo.Rubros, 
                      PR_RubroParo.Tipo, PR_ParoDetalle.Duracion / 60 AS Duracion, PR_ParoDetalle.ProduccionDiferida, PR_Paro.Comentarios, 
                      CASE PR_ParoDetalle.Finalizado WHEN 0 THEN 'No' ELSE 'Si' END AS Finalizado, PR_ParoDetalle.ProduccionDiferidaB
FROM         PR_Paro INNER JOIN
                      PR_ParoDetalle ON PR_Paro.Id = PR_ParoDetalle.IdParo INNER JOIN
                      PR_Pozo ON PR_Paro.Pozo = PR_Pozo.Id INNER JOIN
                      PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN
                      PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id INNER JOIN
                      PR_ListaGeneral ON PR_Pozo.TipoSistema = PR_ListaGeneral.Id INNER JOIN
                      PR_RubroParo ON PR_Paro.Motivo = PR_RubroParo.Id
WHERE     (PR_ParoDetalle.Inicio >= @inicio) AND (PR_ParoDetalle.Inicio < @fin)
END

