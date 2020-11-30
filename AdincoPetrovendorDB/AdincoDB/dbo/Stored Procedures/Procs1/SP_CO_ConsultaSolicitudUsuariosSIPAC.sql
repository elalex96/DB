-- =============================================
-- Author:		Marcos Garcia
-- Create date: 14-02-2020
-- Description:	Consulta Datos de CO_SolicitudUsuariosSIPAC por Contrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaSolicitudUsuariosSIPAC]
--[SP_CO_ConsultaSolicitudUsuariosSIPAC]3,1
--  the parameters for the stored procedure here 
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         SELECT SUS.IdSolicitudUsuariosSIPAC, 
                SUS.IdContrato, 
                SUS.IdContrComerAsigFMP, 
                SUS.IdUsuarioSIPAC, 
                SUS.Nombre, 
                SUS.Apellido, 
                SUS.Correo,
                CASE
                    WHEN SUS.IdPerfilAsignado = 1
                    THEN 'Validación'
                    WHEN SUS.IdPerfilAsignado = 2
                    THEN 'Reporte'
                    WHEN SUS.IdPerfilAsignado = 3
                    THEN 'Consulta'
                    WHEN SUS.IdPerfilAsignado = 4
                    THEN 'NA'
                END AS PerfilAsignado, 
                SUS.IdPerfilAsignado, 
                SUS.RFC,
                CASE
                    WHEN SUS.IdAccion = 1
                    THEN 'Alta de Usuario'
                    WHEN SUS.IdAccion = 2
                    THEN 'Baja de Usuario'
                    WHEN SUS.IdAccion = 3
                    THEN 'Cambio de Perfil'
                    WHEN SUS.IdAccion = 4
                    THEN 'Asignar el Contrato'
                    WHEN SUS.IdAccion = 5
                    THEN 'Desasociar el Contrato'
                END AS Accion, 
                SUS.IdAccion,
                CASE
                    WHEN SUS.IdFacultado = 0
                    THEN 'NO'
                    WHEN SUS.IdFacultado = 1
                    THEN 'SI'
                END AS Facultado, 
                SUS.IdFacultado, 
                UC.Nombre AS CreadoPor, 
                SUS.CreadoEn, 
                UM.Nombre AS ModificadoPor, 
                SUS.ModificadoEn
         FROM dbo.CO_SolicitudUsuariosSIPAC SUS
              LEFT JOIN dbo.AP_Usuario UC ON SUS.CreadoPor = UC.UsuarioID
              LEFT JOIN dbo.AP_Usuario UM ON SUS.ModificadoPor = UM.UsuarioID
         WHERE SUS.IdContrato = @IdContrato
         ORDER BY SUS.IdSolicitudUsuariosSIPAC DESC;
     END;