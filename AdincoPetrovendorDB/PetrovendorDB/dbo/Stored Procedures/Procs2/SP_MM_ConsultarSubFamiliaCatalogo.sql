-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarSubFamiliaCatalogo]
@Familia INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT MS.IdSubFamilia,MS.SubFamilia FROM [dbo].[PV_MM_MaterialSubFamilia] MS
   INNER JOIN [dbo].[PV_MM_GrupoFamiliaSubFamiliaUnidadTipo] A
   ON MS.IdSubFamilia = A.IdSubFamilia 
   WHERE A.IdFamilia = @Familia

END

