import 'src/dependency_injection/annotations.dart';
import 'src/hosting/annotations.dart';
import 'src/mvc/annotations.dart';
import 'src/event/annotations.dart';

// Pub-Sub

// Validation

// Dependency Injection
typedef Components = ComponentsAnnotation;
typedef Component = ComponentAnnotation;

// Hosting
typedef Module = ModuleAnnotation;

// HTTP

// MVC
typedef Controllers = ControllersAnnotation;
typedef Controller = ControllerAnnotation;
typedef ApiController = ApiControllerAnnotation;
typedef RouteMapping = RouteMappingAnnotation;
typedef GetRoute = GetRouteAnnotation;
typedef PostRoute = PostRouteAnnotation;
typedef PutRoute = PutRouteAnnotation;
typedef PatchRoute = PatchRouteAnnotation;
typedef DeleteRoute = DeleteRouteAnnotation;

// Event
typedef EventListeners = EventListenersAnnotation;
typedef EventListener = EventListenerAnnotation;
