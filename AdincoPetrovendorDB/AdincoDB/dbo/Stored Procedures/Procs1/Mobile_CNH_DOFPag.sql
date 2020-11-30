create PROCEDURE [dbo].[Mobile_CNH_DOFPag]
    @IdRegulacion INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
  SELECT IdDof,Titulo1,Descripcion,URLAnexo FROM AM_PublicacionDOF	WHERE IdRegulacion = @IdRegulacion

