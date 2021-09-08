USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_ValidarContratoImportacionEntregables]    Script Date: 07/09/2021 11:40:33 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ValidarContratoImportacionEntregables] --10103,10152
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT = NULL
AS
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/06/2021>
-- Description:	<Consulta de entregables para importacion>
-- =============================================
-- Author:		<Luis David De La Cruz>
-- Create date: <26/08/2021>
-- Description:	<Formato para Shell>
-- =============================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @RESPONSE NVARCHAR(100) = '';
	DECLARE @PERMISO BIT = 0;
    -- Insert statements for procedure here
	IF @IdContrato IN (10093,10108,10110,10119,10120,10122)--REPSOL
	BEGIN

		IF ISNULL(@IdUsuario,0) <> 0
		BEGIN
			SET @RESPONSE= ''
		END
		ELSE
		BEGIN
			SET @RESPONSE= 'REPSOL'
		END
		
	END

	IF @IdContrato IN (3,10039,10047,10048,10049,10050,10054,10055,10056,10057,10058)--Eni. Equinor, Murphy, Carso, Smart (México)
	BEGIN

		IF ISNULL(@IdUsuario,0) <> 0
		BEGIN
			SET @RESPONSE= ''
		END
		ELSE
		BEGIN
			SET @RESPONSE= 'ADINCO'
		END
		
	END

	IF @IdContrato IN (10101,10103,10104,10106,10107,10112,10113,10115,10118,10131) --SHELL
	BEGIN
		
		IF ISNULL(@IdUsuario,0) <> 0
		BEGIN
			--VALIDACION PARA LOS USUARIOS DE SELL QUE TENGAN ACCESO AL AREA DE HSSE
			SELECT 
				@PERMISO = ISNULL( PU.BitActivo,0)
			FROM AP_Permiso P
				LEFT JOIN  AP_PermisosUsuarios PU  
					ON P.IdPermiso = PU.IdPermiso AND PU.UsuarioID = @IdUsuario
				INNER JOIN AP_Usuario U 
					ON U.UsuarioID = @IdUsuario AND P.IdPermiso = 44 --HSSE


			IF @PERMISO = 1
			BEGIN

				SET @RESPONSE= 'SHELL-HSSE'

			END
			ELSE
			BEGIN 
				
				SET @RESPONSE= 'SHELL'

			END

		END
		ELSE
		BEGIN 

			SET @RESPONSE= 'SHELL'
			
		END

		
	END

	--SET @RESPONSE= 'SHELL'
	--SET @RESPONSE= 'SHELL-HSSE'
	--SET @RESPONSE= ''

	SELECT @RESPONSE AS RESPONSE

END
