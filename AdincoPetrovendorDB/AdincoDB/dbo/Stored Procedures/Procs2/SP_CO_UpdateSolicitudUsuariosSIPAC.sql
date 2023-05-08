-- =============================================
-- Author:		Marcos Garcia
-- Create date: 18-02-2020
-- Description:	Update a CO_SolicitudUsuariosSIPAC por @IdUsuarioSolicitud
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_UpdateSolicitudUsuariosSIPAC]
--  the parameters for the stored procedure here 
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
         UPDATE dbo.CO_SolicitudUsuariosSIPAC
           SET 
               IdUsuarioSIPAC = @IdUsuarioSIPAC, 
               Nombre = @Nombre, 
               Apellido = @Apellido, 
               Correo = @Correo, 
               IdPerfilAsignado = @IdPerfilAsignado, 
               RFC = @RFC, 
               IdAccion = @IdAccion, 
               IdFacultado = @IdFacultado, 
               ModificadoPor = @IdUsuario, 
               ModificadoEn = GETDATE()
         WHERE IdSolicitudUsuariosSIPAC = @IdUsuarioSolicitud
               AND IdContrato = @IdContrato;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;