CREATE PROCEDURE [dbo].[sp_ObtieneEsSensibleEntregable] --3,10641,10061
  	@idContrato	INT,
	@idUsuario	INT,
	@idInstancia INT
AS
BEGIN
-- ============================================================
-- Modulo:			SUBIR ENTREGABLE
--------------------------------------------------------------
-- 20200229 REYNA OLVERA
-- ============================================================
    SET NOCOUNT ON;

 SELECT ISNULL(CE.ContieneInformacionSensible,0) as ContieneInformacionSensible
 FROM 
 EN_ContratoEntregable CE
 JOIN	EN_InstanciasEntregable	IE ON	CE.IdContratoEntregable	=	IE.IdContratoEntregable
	AND	IE.idInstanciaEntregable	=	@idInstancia
END;
