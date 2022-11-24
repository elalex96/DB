--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--╔═════════════════════════════════════════════╗
--║Create Author: Marcos Garcia                 ║
--║Create Date:   12-03-2020                    ║
--║Description:   Update a Proveedor Mediante ID║
--╚═════════════════════════════════════════════╝
--Modificado Por: Daniel Moreno
--Modificado El: 28/04/2022
--Descripción: Se agrega campo Actio AL update
CREATE PROCEDURE [dbo].[SP_PV_ActualizarProveedor] 
--
@IdSubcontratista    INT, 
@RFC                 NVARCHAR(MAX), 
@TipoPersonaFiscalID INT, 
@NacionalidadID      INT, 
@RegimenCapital      NVARCHAR(MAX), 
@NombreComercial     NVARCHAR(MAX), 
@IdUsuario           INT, 
@IdContrato          INT,
@IsActivo BIt
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
               ModificadoEn = GETDATE(),
			   IsActivo = ISNULL(@IsActivo,0),
			   IsEliminado = CASE WHEN ISNULL(@IsActivo,0) = 1 THEN 0 ELSE 1 END
         WHERE IdSubcontratista = @IdSubcontratista;
      --╔══════════════════════════╗
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
      --╚══════════════════════════╝
     END;

