CREATE PROCEDURE [dbo].[sp_Obten_AP_PermisosEntregablesUsuarios]--10061,3,2
	@IdUsuario INT,
	@IdContrato INT,
	@IdUsuarioSession INT 
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #PERMISO(IdPermiso INT,NombrePermiso VARCHAR(250));
	
	INSERT INTO #PERMISO(IdPermiso,NombrePermiso)
	SELECT DISTINCT P.IdPermiso,P.NombrePermiso
	FROM AP_PERMISOSUSUARIOS    PU
	JOIN AP_PERMISO P
		ON PU.IDPERMISO = P.IDPERMISO
	WHERE PU.IDCONTRATO   =@IdContrato
		  AND P.BitActivo = 1
		  AND NombrePermiso LIKE '%Entregable%'

	SELECT  P.IdPermiso AS IdPermiso,
			P.NombrePermiso AS NombrePermiso,
			ISNULL( PU.BitActivo,0) AS Activo
	FROM #PERMISO P
		LEFT JOIN  AP_PermisosUsuarios PU  ON P.IdPermiso = PU.IdPermiso 
				AND PU.UsuarioID  = @IdUsuario 
				AND PU.idContrato = @IdContrato
	ORDER BY ISNULL( PU.BitActivo,0) Desc

END




