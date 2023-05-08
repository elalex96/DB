create PROCEDURE [dbo].[Mobile_CNH_AnexosPag]
    @Idregulacion  INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
	SELECT IdAnexoPag,Titulo1,Descripcion,URLAnexo FROM AM_AnexosCNH WHERE IdRegulacion =@Idregulacion

