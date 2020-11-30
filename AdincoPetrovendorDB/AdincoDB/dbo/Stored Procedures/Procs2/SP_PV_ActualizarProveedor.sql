--╔═════════════════════════════════════════════╗
--║Create Author: Marcos Garcia                 ║
--║Create Date:   12-03-2020                    ║
--║Description:   Update a Proveedor Mediante ID║
--╚═════════════════════════════════════════════╝
CREATE PROCEDURE [dbo].[SP_PV_ActualizarProveedor] 
--
@IdSubcontratista    INT, 
@RFC                 NVARCHAR(MAX), 
@TipoPersonaFiscalID INT, 
@NacionalidadID      INT, 
@RegimenCapital      NVARCHAR(MAX), 
@NombreComercial     NVARCHAR(MAX), 
@IdUsuario           INT, 
@IdContrato          INT
AS
     BEGIN
         UPDATE dbo.PV_Subcontratista
           SET 
               RFC = @RFC, 
               NacionalidadID = @NacionalidadID, 
               NombreComercial = @NombreComercial, 
               RegimenCapital = @RegimenCapital, 
               TipoPersonaFiscalID = @TipoPersonaFiscalID, 
               RazonSocial = @NombreComercial, 
               ModificadoPor = @IdUsuario, 
               ModificadoEn = GETDATE()
         WHERE IdSubcontratista = @IdSubcontratista;
      --╔══════════════════════════╗
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
      --╚══════════════════════════╝
     END;