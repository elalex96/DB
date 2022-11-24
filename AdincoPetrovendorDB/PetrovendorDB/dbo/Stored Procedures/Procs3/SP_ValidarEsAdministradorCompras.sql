-- =============================================
-- Author:		Daniel AC
-- Create date: 13/08/2018
-- Description:	Guardar los roles del usuario
-- =============================================

CREATE PROCEDURE [dbo].[SP_ValidarEsAdministradorCompras] 

@IdUsuario INT, 
@IdProveedor INT

AS
	BEGIN

		DECLARE @EsAdministradorCompras BIT =0
		DECLARE @EsTipoAdministrador BIT = 0
		DECLARE @EsAdministrador BIT =0

		--CONSULTAR SI EL USUARIO ACTUAL ES ADMINISTRADOR DE COMPRAS
		SELECT  @EsAdministradorCompras=Activo
		FROM dbo.CC_AdministradorCompras 
		WHERE IdUsuario=@IdUsuario 
		AND Activo=1
		AND IdProveedor=@IdProveedor
		
		--CONSULTAR SI EL USUARIO ACTUAL ES USUARIO DE TIPO ADMINISTRADOR 
		SELECT @EsTipoAdministrador=CASE WHEN COUNT(1)> 0 THEN 1 ELSE 0 END
		FROM dbo.S_Usuario U 
		WHERE U.IdTipoUsuario=3 --> CTE DE TIPO DE USUARIO ADMINISTRADOR 
		AND U.IdUsuario=@IdUsuario

		--SI CUMPLE ALGUNO DE ESTOS PARAMETROS ES UN ADMINISTRADOR Y PUEDE VER TODAS LAS PETICIONES DE SOL OFERTA
		-- SI NO SOLO PODRÁ VER LAS SOL OFERTA DONDE FUE ASIGNADO
		IF ISNULL(@EsTipoAdministrador,0)=1 OR ISNULL(@EsAdministradorCompras,0) =1
		BEGIN
         SET @EsAdministrador =1
		END 

		SELECT @EsAdministrador AS EsAdministrador
		
	END
