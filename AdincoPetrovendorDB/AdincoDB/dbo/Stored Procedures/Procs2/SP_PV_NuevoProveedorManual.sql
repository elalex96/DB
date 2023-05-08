--╔═════════════════════════════════════════════════════════════╗
--║Alter Author: Marcos Garcia                                  ║
--║Alter Date:   12-03-2020                                     ║
--║Description:  *Agregar Variables @Usuario,@Contrato          ║
--║              *Agregar al Insert Creado Por,Creado En        ║
--║              *Agregar al Update Modificado Por,Modificado En║
--╚═════════════════════════════════════════════════════════════╝
CREATE PROCEDURE [dbo].[SP_PV_NuevoProveedorManual] 
--
@RFC_            VARCHAR(50), 
@PersonaFiscal   INT, 
@Regimen         VARCHAR(50), 
@Nacionalidad    INT, 
@NombreComercial VARCHAR(100), 
@IdUsuario       INT, 
@IdContrato      INT
AS
     BEGIN
         DECLARE @RFCReplace AS NVARCHAR(MAX);
         --===============
         SET @RFCReplace =
         (
             SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@RFC_, '!', ''), '#', ''), '$', ''), ' ', ''), '-', ''), '_', ''), '.', '')
         );
         IF 0 =
         (
             SELECT COUNT(1)
             FROM PV_Subcontratista
             WHERE RFC = @RFCReplace
         )
             BEGIN

                 --===============
                 INSERT INTO PV_Subcontratista
                 (RFC, 
                  NacionalidadID, 
                  NombreComercial, 
                  RegimenCapital, 
                  TipoPersonaFiscalID, 
                  RazonSocial, 
                  CreadoPor, 
                  CreadoEn
                 )
                 VALUES
                 (@RFCReplace, 
                  @Nacionalidad, 
                  @NombreComercial, 
                  @Regimen, 
                  @PersonaFiscal, 
                  @NombreComercial, 
                  @IdUsuario, 
                  GETDATE()
                 );
             END;
             ELSE
             BEGIN
                 UPDATE dbo.PV_Subcontratista
                   SET 
                       RazonSocial = @NombreComercial, 
                       NacionalidadID = @Nacionalidad, 
                       NombreComercial = @NombreComercial, 
                       RegimenCapital = @Regimen, 
                       TipoPersonaFiscalID = @PersonaFiscal, 
                       IsEliminado = 0, 
                       IsActivo = 1, 
                       ModificadoPor = @IdUsuario, 
                       ModificadoEn = GETDATE()
                 WHERE RFC = @RFCReplace;
             END;
     END;