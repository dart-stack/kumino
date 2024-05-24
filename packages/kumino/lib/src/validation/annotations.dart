class Validatable {
  const Validatable();
}

class Required {
  const Required();
}

class OneOf {
  const OneOf({
    required this.group,
  });

  final Object group;
}
