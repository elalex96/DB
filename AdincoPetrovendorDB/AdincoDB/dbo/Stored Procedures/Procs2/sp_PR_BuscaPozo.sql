/****** Object:  StoredProcedure [dbo].[BuscaPozo]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE PROCEDURE [dbo].[sp_PR_BuscaPozo] 
	-- Add the parameters for the stored procedure here
	@Pozo nvarchar(MAX)
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: 25 Marzo 2014
-- Description:	Lista de Pozos
-- =============================================

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT        PR_Pozo.Id, PR_Pozo.Clave, PR_Pozo.Nombre, PR_Pozo.Descripcion, PR_ListaGeneral.Nombre AS Estatus, ListaGeneral_1.Nombre AS LDD, PR_Estacion.Nombre AS Estacion, PR_Campo.Nombre AS Campo, PR_Pozo.ProduccionNeta, 
                         PR_Tanque.Nombre AS Tanque, PR_Pozo.UltimoControl
FROM            PR_Pozo INNER JOIN
                         PR_ListaGeneral ON PR_Pozo.Estatus = PR_ListaGeneral.Id INNER JOIN
                         PR_ListaGeneral AS ListaGeneral_1 ON ListaGeneral_1.Grupo = 28 AND PR_Pozo.LDD = ListaGeneral_1.Clave INNER JOIN
                         PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN
                         PR_Campo ON PR_Estacion.Campo = PR_Campo.Id INNER JOIN
                         PR_Tanque ON PR_Pozo.Tanque = PR_Tanque.Id

						 where PR_Pozo.Nombre like '%'+@Pozo+'%' 
    -- Insert statements for procedure here

END

