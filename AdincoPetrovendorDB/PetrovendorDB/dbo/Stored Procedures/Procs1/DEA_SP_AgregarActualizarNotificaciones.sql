-- =============================================
-- Author:	Daniel AC
-- Create date: <20/08/2019>
-- Description:	Actualizar notificaciones de DEA
-- =============================================
CREATE  PROCEDURE [dbo].[DEA_SP_AgregarActualizarNotificaciones] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@TipoNotificacion NVARCHAR(MAX),
	@Usuarios NVARCHAR(MAX),
	@IdCentroCosto INT = NULL 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	CREATE TABLE #UsuarioNotificacion (
    IdUsuario INT
    )

	IF LEN(LTRIM(RTRIM(ISNULL(@Usuarios,'')))) > 0 
	BEGIN 
		INSERT INTO #UsuarioNotificacion
		SELECT Value FROM dbo.Split(LEFT(@Usuarios,(LEN(@Usuarios))),',');
	END   

	DECLARE @FechaModficacion DATETIME  = GETDATE()

	--DESACTIVAR TODOS LOS USUARIOS 
	UPDATE dbo.DEA_UsuariosNotificar
	SET Activo=0,
	IsEliminado=1,
	EliminadoEl=@FechaModficacion,
	EliminadoPor=@IdUsuario
	WHERE TipoNotificacion=@TipoNotificacion
	AND IdProveedor=@IdProveedor
	AND ISNULL(IdCentroCosto,0)=ISNULL(@IdCentroCosto,0)
	
	---VOLVER ACTIVAR LOS USUARIOS QUE VIENEN EL EL ARREGLO DE USUARIOS Y QUE YA TENIAN PERMISOS DE NOTIFICACION
	UPDATE D
	SET D.Activo=1,
	D.IsEliminado=NULL,
	D.EliminadoEl=NULL,
	D.EliminadoPor=NULL	
	FROM dbo.DEA_UsuariosNotificar D
	INNER JOIN #UsuarioNotificacion UN ON UN.IdUsuario = D.IdUsuario
	WHERE D.TipoNotificacion=@TipoNotificacion
	AND D.IdProveedor=@IdProveedor
	AND ISNULL(D.IdCentroCosto,0)=ISNULL(@IdCentroCosto,0)

	---INSERTAR TODOS ESOS USUARIOS QUE NO ESTAN EN DEA_UsuariosNotificar PERO SE SELECCIONARON 
		
	INSERT INTO dbo.DEA_UsuariosNotificar
	(IdUsuario, CreadoPor, CreadoEl,Activo,TipoNotificacion,IdProveedor, IdCentroCosto)	

	SELECT UN.IdUsuario, @IdUsuario, @FechaModficacion, 1,@TipoNotificacion, @IdProveedor, @IdCentroCosto
	FROM #UsuarioNotificacion UN  
	WHERE UN.IdUsuario NOT IN (SELECT IdUsuario 
							 FROM dbo.DEA_UsuariosNotificar 
							 WHERE TipoNotificacion=@TipoNotificacion 
							 AND IdProveedor=@IdProveedor
							 AND ISNULL(IdCentroCosto,0)=ISNULL(@IdCentroCosto,0)
							 ) 
	  
	SELECT 'SUCCESS'



END



