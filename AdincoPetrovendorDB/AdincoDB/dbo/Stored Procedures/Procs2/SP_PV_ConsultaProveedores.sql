
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--╔════════════════════════════════════════╗
--║Create Author: Marcos Garcia            ║
--║Create Date:   12-03-2020               ║
--║Description:   Seleciona los Proveedores║
--╚════════════════════════════════════════╝
--Modificado Por: Daniel Moreno
--Modificado El: 28/04/2022
--Descripción: Se agrega campo Actio
CREATE PROCEDURE [dbo].[SP_PV_ConsultaProveedores] 
--
@IdUsuario  INT = 0, 
@IdContrato INT = 0
AS
     BEGIN
         SELECT PS.IdSubcontratista, 
                PS.RFC, 
				PS.NombreComercial,                 
                PS.TipoPersonaFiscalID, 
                PTPF.TipoPersonaFiscal, 
                PS.NacionalidadID, 
                PN.Nacionalidad, 
				PS.RegimenCapital,                
                ac.Nombre AS CreadoPor,                
                PS.CreadoEn, 
                AM.Nombre AS ModificadoPor,                
                PS.ModificadoEn,
				PS.RazonSocial,
				IsActivo =ISNULL(PS.IsActivo,0)
         FROM dbo.PV_Subcontratista PS
              LEFT JOIN dbo.AP_Usuario AC ON PS.CreadoPor = AC.UsuarioID
              LEFT JOIN dbo.AP_Usuario AM ON PS.ModificadoPor = AM.UsuarioID
              JOIN dbo.PV_TipoPersonaFiscal PTPF ON PS.TipoPersonaFiscalID = PTPF.TipoPersonaFiscalID
              JOIN dbo.PV_Nacionalidad PN ON PS.NacionalidadID = PN.NacionalidadID
         ORDER BY PS.IdSubcontratista DESC;	 
     END;

