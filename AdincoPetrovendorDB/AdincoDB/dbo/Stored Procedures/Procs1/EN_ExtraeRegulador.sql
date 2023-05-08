-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/04/2018
-- Description:	Extrae regulador
-- =============================================
CREATE PROCEDURE [dbo].[EN_ExtraeRegulador]--10061,3
	
	@idUsuario int,
	@idContrato int
AS
BEGIN

	SET NOCOUNT ON;

	 Select Distinct( EN.idRegulador) as idRegulador,Regulador
    FROM EN_instanciasEntregable IE
        JOIN EN_contratoEntregable CE
            ON CE.idContratoEntregable = IE.IdContratoENtregable AND ce.IdContrato=@idContrato
        JOIN EN_estatus E
            ON E.idEstatus = IE.Estatus
        JOIN CO_contrato C
            ON C.idContrato = CE.idContrato 
        JOIN EN_entregable EN
            ON EN.idEntregable = CE.idEntregable
			JOIN dbo.CO_Regulador R ON R.IdRegulador = EN.IdRegulador
			JOIN dbo.EN_MarcoLegal M ON M.IdMarcoLegal = EN.IdMarcoLegal
    WHERE IE.Estatus IN ( 10000, 10005 )
          AND CE.UsuarioElabora = @idUsuario;
    
--	Select Distinct( E.idRegulador) as idRegulador,Regulador from  
--EN_Entregable E 
--Join [CO_Regulador] RE on E.idRegulador= RE.idRegulador
END