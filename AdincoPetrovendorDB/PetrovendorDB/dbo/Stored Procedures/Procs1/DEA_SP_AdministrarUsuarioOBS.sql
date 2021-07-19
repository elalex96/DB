USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_AdministrarUsuarioOBS'
)
    DROP PROCEDURE DEA_SP_AdministrarUsuarioOBS;

/****** Object:  StoredProcedure [dbo].[sp_CentroCostoFiltro_Grd]    Script Date: 13/07/2021 01:17:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[DEA_SP_AdministrarUsuarioOBS]
@TipoConsulta NVARCHAR(MAX),
@ContratoId INT = 0,
@UsuarioId INT = 0
AS
BEGIN

	DECLARE @Contador INT = 0

	IF @TipoConsulta ='AGREGAR'
	BEGIN 
		
		SELECT @Contador=COUNT(1) 
		FROM DEA_UsuarioOBS 
		WHERE IdContrato = @ContratoId
		AND IdUsuario = @UsuarioId
			
		IF @Contador>0
		BEGIN 
			/*ACTIVAR USUARIO*/
			UPDATE DEA_UsuarioOBS
			SET Activo= 1,
			ModificadoEl = GETDATE()
			WHERE IdContrato = @ContratoId
			AND IdUsuario = @UsuarioId			
		END 
		ELSE 
		BEGIN
			/*AGREGAR USUARIO*/
			INSERT INTO DEA_UsuarioOBS(IdUsuario, IdContrato,CreadoEl,Activo)
			VALUES(@UsuarioId,@ContratoId,GETDATE(),1)
		END 
	END 

	IF @TipoConsulta ='ELIMINAR'
	BEGIN 

		/*DESACTIVAR USUARIO*/
		UPDATE DEA_UsuarioOBS
		SET Activo= 0,
		ModificadoEl = GETDATE()
		WHERE IdContrato = @ContratoId
		AND IdUsuario = @UsuarioId	

	END 
			
END

