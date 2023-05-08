-- =============================================
-- Author:		Manuel CD
-- Create date: 18-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ActualizarInstalaciones]
	-- Add the parameters for the stored procedure here
@NombreInstalacion        NVARCHAR(MAX),
@EsBolsa                  BIT,
@NombreActividad          INT,
@NombreInstalacionAlterno NVARCHAR(MAX),
@Activo                   BIT,
@CUIP                     NVARCHAR(MAX),
@WelIID                   INT,
@NombreCampo              INT,
@UTMX                     FLOAT,
@UTMY                     FLOAT,
@IdUsuario                INT,
@IdInstalacion            INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         UPDATE [dbo].[CO_Instalacion]
           SET
               [NombreInstalacion] = @NombreInstalacion,
               [EsBolsa] = @EsBolsa,
               [IdActividad] = @NombreActividad,
               [NombreInstalacionAlterno] = @NombreInstalacionAlterno,
               [Activo] = @Activo,
               [CUIP] = @CUIP,
               [WelIID] = @WelIID,
               [IdCampo] = @NombreCampo,
               [UTMX] = @UTMX,
               [UTMY] = @UTMY,
               [ModificadoPor] = @IdUsuario,
               [ModificadoEn] = GETDATE()
         WHERE IdInstalacion = @IdInstalacion;
     END;

