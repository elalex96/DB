-- =============================================
-- Author:		Marcos Garcia
-- Create date: 2020-02-10
-- Description:	Validaciones 
--				0 = Nuevo Registro
--				1 = Editar Registro
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ValidacionesSolicitudUsuariosSIPAC] 
-- Add the parameters for the stored procedure here
@TipoValidacion     INT, 
@IdUsuarioSolicitud INT, 
@IdAccion           INT, 
@IdPerfilAsignado   INT, 
@IdFacultado        INT, 
@IdUsuarioSIPAC     NVARCHAR(MAX), 
@Nombre             NVARCHAR(MAX), 
@Apellido           NVARCHAR(MAX), 
@Correo             NVARCHAR(MAX), 
@RFC                NVARCHAR(MAX), 
@IdContrato         INT, 
@IdUsuario          INT
AS
     BEGIN
         IF OBJECT_ID('tempdb..#ValidacionesSUSIPAC', 'U') IS NOT NULL
             DROP TABLE #ValidacionesSUSIPAC;
         CREATE TABLE #ValidacionesSUSIPAC(Validaciones NVARCHAR(MAX));
         --Nuevo Registro
         IF(@TipoValidacion = 0)
             BEGIN
                 IF EXISTS
                 (
                     SELECT *
                     FROM dbo.CO_SolicitudUsuariosSIPAC
                     WHERE IdContrato = @IdContrato
                           AND Correo = @Correo
                 )
                     BEGIN
                         INSERT INTO #ValidacionesSUSIPAC(Validaciones)
                                SELECT 'El corre ['+@Correo+'] ya ha sido registrado previamente en el Id Registro ['+CONVERT(NVARCHAR(MAX), IdSolicitudUsuariosSIPAC)+'].'
                                FROM dbo.CO_SolicitudUsuariosSIPAC
                                WHERE IdContrato = @IdContrato
                                      AND Correo = @Correo;
                     END;
                     ELSE
                     BEGIN
                         IF EXISTS
                         (
                             SELECT *
                             FROM dbo.CO_SolicitudUsuariosSIPAC
                             WHERE IdContrato = @IdContrato
                                   AND IdUsuarioSIPAC = @IdUsuarioSIPAC
                                   AND IdUsuarioSIPAC <> 'NA'
                                   AND IdUsuarioSIPAC <> ''
                         )
                             BEGIN
                                 INSERT INTO #ValidacionesSUSIPAC(Validaciones)
                             SELECT 'El Id del Usuario en el SIPAC ['+@IdUsuarioSIPAC+'] ya ha sido registrado previamente con el correo ['+Correo+'] en el Id Registro ['+CONVERT(NVARCHAR(MAX), IdSolicitudUsuariosSIPAC)+'].'
                             FROM dbo.CO_SolicitudUsuariosSIPAC
                             WHERE IdContrato = @IdContrato
                                   AND IdUsuarioSIPAC = @IdUsuarioSIPAC
                                   AND IdUsuarioSIPAC <> 'NA'
                                   AND IdUsuarioSIPAC <> ''
                             END;
                     END;
             END;
         --Edición de Registro
         IF(@TipoValidacion = 1)
             BEGIN
                 IF EXISTS
                 (
                     SELECT *
                     FROM dbo.CO_SolicitudUsuariosSIPAC
                     WHERE IdSolicitudUsuariosSIPAC <> @IdUsuarioSolicitud
                           AND Correo = @Correo
                           AND IdContrato = @IdContrato
                 )
                     BEGIN
                         INSERT INTO #ValidacionesSUSIPAC(Validaciones)
                                SELECT 'El corre ['+@Correo+'] ya ha sido registrado previamente en el Id Registro ['+CONVERT(NVARCHAR(MAX), IdSolicitudUsuariosSIPAC)+'].'
                                FROM dbo.CO_SolicitudUsuariosSIPAC
                                WHERE IdSolicitudUsuariosSIPAC <> @IdUsuarioSolicitud
                                      AND Correo = @Correo
                                      AND IdContrato = @IdContrato;
                     END;
                     ELSE
                     BEGIN
                         IF EXISTS
                         (
                             SELECT *
                             FROM dbo.CO_SolicitudUsuariosSIPAC
                             WHERE IdContrato = @IdContrato
                                   AND IdSolicitudUsuariosSIPAC <> @IdUsuarioSolicitud
                                   AND IdUsuarioSIPAC = @IdUsuarioSIPAC
                                   AND IdUsuarioSIPAC <> 'NA'
                                   AND IdUsuarioSIPAC <> ''
                         )
                             BEGIN
                                 INSERT INTO #ValidacionesSUSIPAC(Validaciones)
                             SELECT 'El Id del Usuario en el SIPAC ['+@IdUsuarioSIPAC+'] ya ha sido registrado previamente con el correo ['+Correo+'] en el Id Registro ['+CONVERT(NVARCHAR(MAX), IdSolicitudUsuariosSIPAC)+'].'
                             FROM dbo.CO_SolicitudUsuariosSIPAC
                             WHERE IdContrato = @IdContrato
                                   AND IdUsuarioSIPAC = @IdUsuarioSIPAC
                                   AND IdUsuarioSIPAC <> 'NA'
                                   AND IdUsuarioSIPAC <> ''
                             END;
                     END;
             END;
         SELECT Validaciones
         FROM #ValidacionesSUSIPAC;
     END;