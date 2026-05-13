-- =============================================
-- Author:		Miguel
-- Create date: 1-1-2017
-- Description:	
-- =============================================
CREATE PROCEDURE [sp_SC_ConsultaListadoProveedores] 
-- Add the parameters for the stored procedure here
@IdContrato INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT S.IdSubcontratista,
                S.RFC,
                S.RazonSocial,
                S.RepresentanteLegal,
                S.DiasCreditoID,
                S.Giro,
                S.PatronalIMSS,
                S.Capital,
                S.IdStatusValidacion,
                S.MotivoRechazo,
                S.NombreComercial,
                S.CURP,
                S.FormaPagoID,
                S.GrupoCuentasID,
                S.UsuarioID,
                CS.IdContratistaSubcontratista,
                CS.IdContratista,
                CS.IdSubcontratista AS Expr1,
                CS.Relacionada,
                PV_TipoPersonaFiscal.TipoPersonaFiscal,
                PV_Nacionalidad.Nacionalidad,
                PV_ClasificacionEmpresa.Clasificacion
         FROM PV_Subcontratista AS S
              INNER JOIN CO_ContratistaSubcontratista AS CS ON S.IdSubcontratista = CS.IdSubcontratista
              INNER JOIN CO_Contrato AS C ON C.IdContratista = CS.IdContratista
              INNER JOIN PV_TipoPersonaFiscal ON S.TipoPersonaFiscalID = PV_TipoPersonaFiscal.TipoPersonaFiscalID
              INNER JOIN PV_Nacionalidad ON S.NacionalidadID = PV_Nacionalidad.NacionalidadID
              INNER JOIN PV_ClasificacionEmpresa ON S.ClasificacionID = PV_ClasificacionEmpresa.ClasificacionID
         WHERE(C.IdContrato = @IdContrato);
     END;
