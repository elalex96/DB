USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Sp_EsRequeridaCartaContenido'
)
    DROP PROCEDURE Sp_EsRequeridaCartaContenido;
	GO
/****** Object:  StoredProcedure [dbo].[Sp_EsRequeridaCartaContenido]    Script Date: 17/06/2022 03:03:32 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/10/2019
-- Description:	Revisa si la carta de contenido es requerida o no, 
--				se utiliza en la pantalla de aceptacion pedido detalle, para llenar el check de carta de contenido
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 13/09/2021
-- Description:	SE VALIDA QUE CUANDO SEA PROVEEDOR EXTRANGERO SE MUESTRE EL SWITCH COMO NO
-- =============================================
CREATE PROCEDURE [dbo].[Sp_EsRequeridaCartaContenido] @IdAceptacionPedido INT
AS
BEGIN

	
	DECLARE @IsAceptacionExtranjera INT 
	DECLARE @PedirCarta INT =0

	SELECT @IsAceptacionExtranjera=IdNacionalidadProveedor
			FROM MM_AceptacionPedido 			
			WHERE IdAceptacionPedido=@IdAceptacionPedido

	IF  ISNULL(@IsAceptacionExtranjera,0)=2
	BEGIN 
	
		SELECT   
		@PedirCarta = CASE WHEN  ISNULL(A.IdAceptacionPedido,0)	>0 THEN 	1 ELSE 0 END
		FROM dbo.MM_Pedido AS P   
		JOIN MM_AceptacionPedido AS A 
			ON P.IdPedido = A.IdPedido
		JOIN DEA_SolicitudCNProveedorExtranjero SCNP
			ON P.IdSubcontratista = SCNP.IdProveedor
			AND P.IdContrato =  SCNP.IdContrato
			AND SCNP.Activo=1  --> CTE QUE ESTE ACTIVO EL PERMISO		
		JOIN RelacionCartaCNPedido rel 
			ON A.IdAceptacionPedido    = rel.IdAceptacionPedido 
			AND P.IdPedido  = rel.IdPedido 
			AND rel.PedirCarta = 1 --> CTE 			
		WHERE A.IdAceptacionPedido= @IdAceptacionPedido  	

	END 

    SELECT 
	CASE WHEN P.IdNacionalidad = 2
	THEN @PedirCarta
	ELSE
	ISNULL(PedirCarta, 0) 
	END AS CARTACN
    FROM dbo.RelacionCartaCNPedido as RCN
	JOIN  MM_Pedido AS PD 
	ON RCN.IdPedido = PD.IdPedido
	JOIN S_Proveedor AS P ON
	PD.IdSubcontratista = P.IdProveedor
    WHERE IdAceptacionPedido = @IdAceptacionPedido

    
END