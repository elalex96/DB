-- =============================================
-- Author:		Marcos Garcia
-- Create date: 14-02-2020
-- Description:	Insert CO_SolicitudUsuariosSIPAC por Contrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_InsertSolicitudUsuariosSIPAC]
--  the parameters for the stored procedure here 
@IdAccion         INT, 
@IdPerfilAsignado INT, 
@IdFacultado      INT, 
@IdUsuarioSIPAC   NVARCHAR(MAX), 
@Nombre           NVARCHAR(MAX), 
@Apellido         NVARCHAR(MAX), 
@Correo           NVARCHAR(MAX), 
@RFC              NVARCHAR(MAX), 
@IdContrato       INT, 
@IdUsuario        INT
AS
     BEGIN
         INSERT INTO dbo.CO_SolicitudUsuariosSIPAC
         (IdContrato,           
          IdContrComerAsigFMP, 
          IdUsuarioSIPAC, 
          Nombre, 
          Apellido, 
          Correo, 
          IdPerfilAsignado, 
          RFC, 
          IdAccion, 
          IdFacultado, 
          CreadoPor, 
          CreadoEn, 
          ModificadoPor, 
          ModificadoEn
         )
                SELECT C.IdContrato,                       
                       'NA', 
                       @IdUsuarioSIPAC, 
                       @Nombre, 
                       @Apellido, 
                       @Correo, 
                       @IdPerfilAsignado, 
                       @RFC, 
                       @IdAccion, 
                       @IdFacultado, 
                       @IdUsuario, 
                       GETDATE(), 
                       NULL, 
                       NULL
                FROM dbo.CO_Contrato C
                     JOIN dbo.CO_Contratista CA ON C.IdContratista = CA.IdContratista
                WHERE C.IdContrato = @IdContrato;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;