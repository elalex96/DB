
-- =============================================  
-- Author:  DAVID DE LA CRUZ 
-- Create date: 08/11/2019  
-- Description: Permite agregar LA OPERACION para hacer relacion con un flujo de tareas  
-- =============================================  
CREATE PROCEDURE  [dbo].[p_MPY_TA_AgregarOperacionNotaCredito]   
 -- Add the parameters for the stored procedure here    
 @IdDocumento int,   
 @IdProveedor int,    
 @IdAsignador int,   
 @Descripcion nvarchar(MAX),  
 @IdAceptacionPedido INT  
 AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 DECLARE @FECHA_ACTUAL DATETIME =GETDATE()  
 DECLARE @DescripcionH nvarchar(MAX)  
 DECLARE @IdOperacion int  
 DECLARE @IdTipoOperacion INT = 17 ---> APROBACIÓN DE NOTA DE CREDITO   
  
 -- CONSULTAR EL FLUJO DE APROBACIÓN   
  
 DECLARE @IdFlujoAprobacion int   
 --SELECT @IdFlujoAprobacion= FT.IdFlujoTarea  
 --FROM MM_AceptacionFactura AS AF  
 --INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido  
 --INNER JOIN MM_Pedido   AS P on P.IdPedido= AP.IdPedido   
 --INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras  
 --INNER JOIN TA_FlujoTarea AS FT ON FT.IdProveedor =P.IdProveedorCompras  
 --WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND FT.IdTipoOperacion = 10 AND FT.Activo=1 AND FT.Predeterminado=1
 
 SET @IdFlujoAprobacion = 0; 
    -- Agregar Operación Si IdFlujoTarea =  0 Es una operación que no tiene flujo de tarea  
     
 INSERT INTO TA_Operacion(IdDocumento,IdTipoOperacion,IdFlujoTarea,IdEstatusOperacion,IdEstadoFlujo,IdProveedor,IdAsignador,FechaRegistro,Descripcion, IdVigencia, IdPrioridad)  
 VALUES(@IdDocumento,@IdTipoOperacion,@IdFlujoAprobacion,1,1,@IdProveedor,@IdAsignador,@FECHA_ACTUAL, @Descripcion,NULL,NULL)  
    
  
 SELECT @IdOperacion =  (SCOPE_IDENTITY());  
   
 ----Agregar Evento al Historial del Flujo de Tarea----  
  
 SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdAsignador)+ ' ha registrado la Tarea de Tipo ' + (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion=@IdTipoOperacion)  
  
 INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)  
 VALUES(@IdOperacion,@FECHA_ACTUAL,@DescripcionH,1)  
  
  
 --AGREGAR APROBADORES   
  
 --INSERT INTO dbo.TA_Tarea  
 --(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion)
 --SELECT 
 --'Aprobación de Factura NC',  
 --GETDATE(),   
 --CASE WHEN FT.IdTipoFlujo=1 --> APROBACIÓN SERIAL  
 --AND A.NoSecuencia>1 THEN   
 --9 --> SIN INICIAR APROBACIÓN SOLO APLICA PARA SERIALES DONDE NUM SECUENCIA ES MAYOR A 1   
 --ELSE   
 --1 --> EN APROBACIÓN  
 --END,   
 --1,  
 --0,  
 --A.IdUsuario,  
 --A.NoSecuencia,  
 --@IdOperacion  
 --FROM dbo.TA_Aprobador A  
 --LEFT JOIN dbo.TA_FlujoTarea FT ON FT.IdFlujoTarea = A.IdFlujoTarea --SELECT * FROM dbo.TA_TipoFlujoTarea  
 --WHERE A.IdFlujoTarea= @IdFlujoAprobacion  
 --ORDER BY A.NoSecuencia ASC 
 INSERT INTO dbo.TA_Tarea (NombreTarea,FechaRegistro,
IdEstatus,Activo, Visto,
IdAprobador,NoSecuencia,IdOperacion   )
 SELECT 
 'Aprobación de Factura NC',  
 GETDATE(),
 1,
 1,  
 0,
 US.IdUsuario,
 1,
 @IdOperacion
	FROM dbo.MPY_MM_AceptacionPedido ap 
	LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = ap.IdProveedor
	LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE Modern_Spanish_CI_AS = CO.RFC COLLATE Modern_Spanish_CI_AS
	LEFT JOIN dbo.S_UsuarioProveedor AS UP ON UP.IdProveedor = PR.IdProveedor
	LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = UP.IdUsuario AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
	WHERE ap.IdAceptacionPedido = @IdAceptacionPedido	--3961
		AND US.Activo = 1
		AND ISNULL(US.IsEliminado, 0) = 0
		AND US.IdUsuario IS NOT NULL
	GROUP BY US.IdUsuario, US.Nombre, US.Correo,US.IdTipoUsuario
  
 SELECT @IdOperacion AS IdOperacion  
  
  
  --SELECT   AD.IdTarea,--0  
  --         AD.IdAprobador,--1  
  --         U.Nombre,--2  
  --         U.Correo,--3  
  --         AD.IdOperacion,--4  
  --         AD.NoSecuencia,--5  
  --         PG.IdPedido,--6  
  --         AP.IdAceptacionPedido,--7  
  --         NC.IdAceptacionNotaCredito,--8  
  --         P.IdSolicitudPedido,--9  
  --   P.IdPedido  
  --  FROM dbo.TA_Tarea AD  
  --      INNER JOIN dbo.TA_Operacion A  
  --          ON A.IdOperacion = AD.IdOperacion     
  --      INNER JOIN dbo.S_Usuario U  
  --          ON U.IdUsuario = AD.IdAprobador  
  --      INNER JOIN dbo.MPY_MM_AceptacionNotaCredito NC  
  --          ON NC.IdAceptacionNotaCredito = A.IdDocumento                
  --      INNER JOIN dbo.MPY_MM_AceptacionPedido AP  
  --          ON AP.IdAceptacionPedido = NC.IdAceptacionPedido  
  --      INNER JOIN dbo.MM_Pedido P  
  --          ON P.IdPedido = AP.IdPedido  
  --      INNER JOIN dbo.MM_Pedidos PG  
  --        ON PG.IdIdentificador = P.IdPedido  
  --      AND PG.IdProveedorCliente = P.IdProveedorCompras    
  --  WHERE A.IdOperacion = @IdOperacion   
  --        AND AD.IdEstatus=1 ---> PARA QUE SOLO MANDE NOTIFICACIÓN A LOS APROBADORES QUE ESTAN PENDIENTES DE APROBAR YA SERA SERIAL PARALELO  
  --  AND A.IdTipoOperacion = 17 -->Aprobación de nota de crédito  
  --GROUP BY   AD.IdTarea,--0  
  --         AD.IdAprobador,--1  
  --         U.Nombre,--2  
  --         U.Correo,--3  
  --         AD.IdOperacion,--4  
  --         AD.NoSecuencia,--5  
  --         PG.IdPedido,--6  
  --         AP.IdAceptacionPedido,--7  
  --         NC.IdAceptacionNotaCredito,--8  
  --         P.IdSolicitudPedido,--9  
  --    P.IdPedido  
     
END  