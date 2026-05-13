-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarFamiliaCatalogo]
@IdGrupo INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT MF.IdFamilia,MF.Familia FROM [dbo].[PV_MM_MaterialFamilia] MF
   INNER JOIN [dbo].[PV_MM_GrupoFamiliaSubFamiliaUnidadTipo] A
   ON MF.IdFamilia = A.IdFamilia 
   WHERE A.IdGrupo = @IdGrupo


END

