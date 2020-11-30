-- =============================================
-- Author: Daniel AC
-- Update date: 15/11/2019
-- Description:	Se agrega el retorno de los compradores separados por coma  
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarGrupoComprasCentroCosto] 
@IdProveedor INT ,
@IdContrato INT = NULL, 
@IdUsuario INT = NULL

AS
	BEGIN

		SELECT C.IdCentroCosto, C.CentroCosto, C.numero,dbo.Fn_ObtenerUsuariosComprasCC(C.IdCentroCosto, C.IdProveedor) AS IdUsuarios
		FROM dbo.CC_CentroCosto C
		WHERE IdProveedor=@IdProveedor
		AND ISNULL(C.IsActivo,0)=1
		ORDER BY C.CentroCosto ASC
        
		
	END
