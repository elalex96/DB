-- =============================================
-- Author:		DANIEL AC 
-- Create date: 31/08/2017
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[SP_PV_ValidarEmailUser]-- -2290,'DANIEL_BNT13@HOTMAIL.COM',457,'Compras'

@IdUsuario int,
@Correo varchar(50),
@IdProveedor int, 
@TipoUsuario varchar(50)

AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--- Validar usuario 
	DECLARE @RESPONSE_CORREO  NVARCHAR(300)=  'ERROR'
	DECLARE @RESPONSE_TIPO_USER  NVARCHAR(300)=  'ERROR'
	DECLARE  @CorreoActual  NVARCHAR(300) = (select U.Correo from S_Usuario as U where U.IdUsuario = @IdUsuario)
	DECLARE  @TipoUsuarioActual  INT = (select U.IdTipoUsuario from S_Usuario as U where U.IdUsuario = @IdUsuario)
	DECLARE @COUNT_CORREO INT = (select COUNT(U.Correo) from S_Usuario as U where U.Correo = @Correo  AND U.Activo=1) 
	declare @IdTipoUsuario int = (select TU.IdTipoUsuario from S_TipoUsuario as TU where TU.NombreTipoUsuario = @TipoUsuario)

    IF @CorreoActual = @Correo 
		BEGIN 
			SET @RESPONSE_CORREO = 'CORREO_NO_CHANGE'
		END 
	ELSE
		BEGIN 
			IF @COUNT_CORREO = 0
				BEGIN 
					SET @RESPONSE_CORREO = 'DISPONIBLE'
				END 
			ELSE 
				BEGIN
					SET @RESPONSE_CORREO = 'NO_DISPONIBLE'
				END 

		END 


	--- Validar Tipo Usuario disponible 

	DECLARE @COUNT_USUARIO_DISPONIBLE INT  =(SELECT COUNT(U.IdTipoUsuario) FROM S_Usuario U INNER JOIN S_UsuarioProveedor US ON US.IdUsuario= U.IdUsuario
									   INNER JOIN S_Proveedor AS P ON P.IdProveedor= US.IdProveedor WHERE P.IdProveedor = @IdProveedor  AND U.IdTipoUsuario = @IdTipoUsuario AND U.Activo=1)

	IF @TipoUsuarioActual = @IdTipoUsuario 
		BEGIN 
			SET @RESPONSE_TIPO_USER = 'TU_NO_CHANGE'
		END 
	ELSE
		BEGIN 
			IF @COUNT_USUARIO_DISPONIBLE = 0
				BEGIN 
					SET @RESPONSE_TIPO_USER = 'DISPONIBLE'
				END 
			ELSE 
				BEGIN
					SET @RESPONSE_TIPO_USER = 'NO_DISPONIBLE'
				END 

		END 

		SELECT @RESPONSE_CORREO ,@RESPONSE_TIPO_USER
END


