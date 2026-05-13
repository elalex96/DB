USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_AgregarNuevoModulo'
)
    DROP PROCEDURE SP_AgregarNuevoModulo;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abel Rivera 
-- Create date: 01/03/2017
-- Description:	Administración de módulos de Procura
-- =============================================
-- Author:		Daniel AC 
-- Create date: 05/05/2026
-- Description:	Se agrega información de auditoria
-- =============================================
-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <02/Enero/2018>
-- Description:	<Se agrego el parametro @aplicacion para saber en que aplicacion se esta utilizando Procura o Petrovendor >
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarNuevoModulo]
    @ModuloAspx NVARCHAR(200),
    @IdModulo NVARCHAR(200),
    @URL_MODULO NVARCHAR(200),
    @Aplicacion INT,
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Modulo]
    (
        [NombreModulo],
        [StringModuloId],
        [CreadoPor],
        [CreadoEl],
        [URL_MODULO],
        Aplicacion
    )
    VALUES
    (@ModuloAspx, @IdModulo, @IdUsuario, GETDATE(), @URL_MODULO, @Aplicacion)

    SELECT @@IDENTITY


END
