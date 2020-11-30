-- ================================================
CREATE PROCEDURE [dbo].[AP_ListaPermisosUsuarios]--10082,3,2,3
	
	@UsuarioID INT,-- a editar
	@IdContrato INT,-- Session
	@IdUsuario INT, --Session
	@idContratoCb INT -- combo de contrato seleccionado
AS
BEGIN

	-- =======================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 18/02/2019
	-- Description:	Extrae lista de Permisos para cada usuario
	-- =======================================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Muestra los permisos actuales de los usuarios (Tabla AP_PermisosUsuarios)
	
	--SELECT P.IdPermiso AS IdPermiso,
	--	   PU.UsuarioID AS UsuarioID,
	--	   P.NombrePermiso AS nombrePermiso,
	--	   PU.BitActivo AS BitActivo,
	--	   C.IdContrato AS IdContrato,
	--	   C.NumeroContrato AS numeroContrato
	--	   FROM AP_Permiso P
	--			INNER JOIN AP_PermisosUsuarios PU ON P.IdPermiso = PU.IdPermiso
	--			INNER JOIN AP_Usuario U ON PU.UsuarioID = U.UsuarioID
	--			INNER JOIN CO_Contrato C ON PU.idContrato = C.IdContrato
	--	   WHERE @UsuarioID = PU.UsuarioID AND P.BitActivo = 1;

		   SELECT P.IdPermiso AS IdPermiso,
		   U.UsuarioID AS UsuarioID,
		   P.NombrePermiso AS nombrePermiso,
		  ISNULL( PU.BitActivo,0) AS BitActivo
		   FROM AP_Permiso P
				Left JOIN  AP_PermisosUsuarios PU  ON P.IdPermiso = PU.IdPermiso AND PU.UsuarioID=@UsuarioID --AND PU.idContrato=@idContratoCb
				INNER JOIN AP_Usuario U ON U.UsuarioID = @UsuarioID
				

END